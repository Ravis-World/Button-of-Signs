import argparse
import ctypes
import struct
import sys
from ctypes import wintypes
from pathlib import Path


RT_ICON = 3
RT_GROUP_ICON = 14


def parse_icon(data):
    if len(data) < 6:
        raise ValueError("The icon file is too small to contain an ICO header.")

    reserved, image_type, count = struct.unpack_from("<HHH", data)
    if reserved != 0 or image_type != 1 or count == 0:
        raise ValueError("The icon file has an invalid ICO header.")

    directory_end = 6 + count * 16
    if len(data) < directory_end:
        raise ValueError("The icon file has a truncated image directory.")

    images = []
    group_entries = []
    for index in range(count):
        entry = struct.unpack_from("<4B2H2I", data, 6 + index * 16)
        width, height, colors, reserved_byte, planes, bit_count, size, offset = entry

        if size == 0 or offset < directory_end or offset + size > len(data):
            raise ValueError(f"Icon image {index + 1} has invalid bounds.")

        resource_id = index + 1
        images.append((resource_id, data[offset:offset + size]))
        group_entries.append(
            struct.pack(
                "<4B2HIH",
                width,
                height,
                colors,
                reserved_byte,
                planes,
                bit_count,
                size,
                resource_id,
            )
        )

    group = struct.pack("<HHH", 0, 1, count) + b"".join(group_entries)
    return images, group


def resource_id(value):
    return ctypes.c_void_p(value)


def read_overlay(executable):
    data = executable.read_bytes()
    if len(data) < 64 or data[:2] != b"MZ":
        raise ValueError("The target file is not a valid Windows executable.")

    pe_offset = struct.unpack_from("<I", data, 0x3C)[0]
    if pe_offset + 24 > len(data) or data[pe_offset:pe_offset + 4] != b"PE\0\0":
        raise ValueError("The target file has an invalid PE header.")

    section_count = struct.unpack_from("<H", data, pe_offset + 6)[0]
    optional_size = struct.unpack_from("<H", data, pe_offset + 20)[0]
    section_table = pe_offset + 24 + optional_size
    section_table_end = section_table + section_count * 40
    if section_table_end > len(data):
        raise ValueError("The target file has a truncated section table.")

    section_data_end = section_table_end
    for index in range(section_count):
        section_offset = section_table + index * 40
        raw_size, raw_offset = struct.unpack_from("<II", data, section_offset + 16)
        if raw_size:
            section_data_end = max(section_data_end, raw_offset + raw_size)

    if section_data_end > len(data):
        raise ValueError("The target file has an invalid section boundary.")
    return data[section_data_end:]


def embed_icon(executable, icon_path):
    if sys.platform != "win32":
        raise OSError("Embedding an executable icon is supported only on Windows.")

    data = icon_path.read_bytes()
    images, group = parse_icon(data)
    overlay = read_overlay(executable)

    begin_update = ctypes.WinDLL("kernel32", use_last_error=True).BeginUpdateResourceW
    update = ctypes.WinDLL("kernel32", use_last_error=True).UpdateResourceW
    end_update = ctypes.WinDLL("kernel32", use_last_error=True).EndUpdateResourceW

    begin_update.argtypes = [ctypes.c_wchar_p, wintypes.BOOL]
    begin_update.restype = ctypes.c_void_p
    update.argtypes = [
        ctypes.c_void_p,
        ctypes.c_void_p,
        ctypes.c_void_p,
        wintypes.WORD,
        ctypes.c_void_p,
        wintypes.DWORD,
    ]
    update.restype = wintypes.BOOL
    end_update.argtypes = [ctypes.c_void_p, wintypes.BOOL]
    end_update.restype = wintypes.BOOL

    handle = begin_update(str(executable), False)
    if not handle:
        raise ctypes.WinError(ctypes.get_last_error())

    try:
        for icon_id, image in images:
            buffer = ctypes.create_string_buffer(image)
            if not update(
                handle,
                resource_id(RT_ICON),
                resource_id(icon_id),
                0,
                buffer,
                len(image),
            ):
                raise ctypes.WinError(ctypes.get_last_error())

        buffer = ctypes.create_string_buffer(group)
        if not update(
            handle,
            resource_id(RT_GROUP_ICON),
            resource_id(1),
            0,
            buffer,
            len(group),
        ):
            raise ctypes.WinError(ctypes.get_last_error())
    except Exception:
        end_update(handle, True)
        raise

    if not end_update(handle, False):
        raise ctypes.WinError(ctypes.get_last_error())

    if overlay:
        with executable.open("ab") as updated_executable:
            updated_executable.write(overlay)


def main():
    parser = argparse.ArgumentParser(
        description="Embed an ICO file as a Windows executable's application icon."
    )
    parser.add_argument("executable", type=Path)
    parser.add_argument("icon", type=Path)
    args = parser.parse_args()

    try:
        embed_icon(args.executable, args.icon)
    except (OSError, ValueError) as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
