'''
NOTE: all functions in this file were copied directly from piazza.
This entire file of code is credited to Jason Jewik
'''

import sys
import time
import typing
import warnings
import decimal

latitude, longitude = str, str


def extract_coords(coord_str: str, verbose: bool = False) -> (latitude, longitude):
    """
    Extracts latitude, longitude as an ordered pair from the given coordinate
    string. If the  given coordinate string is not in ISO 6709 format, raises
    ValueError.

    Examples:

    - extract_coords('+34.068930-118.445127') -> ('+34.068930', '-118.445127')
    - extract_coords('foobar') -> ValueError
    - extract_coords('+100-200') -> ValueError
    """
    cs = coord_str.strip()

    # Check for commas
    if ',' in coord_str:
        if verbose:
            print(f'Error: "{coord_str} contains a comma', file=sys.stderr)
        raise ValueError(str)

    # Check for the proper number of sign chars
    num_plus = cs.count('+')
    num_minus = cs.count('-')
    num_signs = num_plus + num_minus
    if num_signs != 2:
        if verbose:
            print(f'Error: "{coord_str}" contains an improper number of sign chars',
                  file=sys.stderr)
        raise ValueError(str)

    # Check that the latitude and longitude are signed
    lat_sign, lon_sign = None, None

    if cs.startswith('+'):
        lat_sign = '+'
    elif cs.startswith('-'):
        lat_sign = '-'
    if lat_sign is None:
        if verbose:
            print(f'Error: "{coord_str}" does not start with a signed latitude',
                  file=sys.stderr)
        raise ValueError(str)

    cs = cs[1:]
    if lat_sign == '+' and num_plus == 2 or lat_sign == '-' and num_minus == 1:
        lon_sign = '+'
    elif lat_sign == '+' and num_plus == 1 or lat_sign == '-' and num_minus == 2:
        lon_sign = '-'
    if lon_sign is None:
        if verbose:
            print(f'Error: "{coord_str} does not contain a signed longitude',
                  file=sys.stderr)
        raise ValueError(str)
    str_ulat, sep, str_ulon = cs.partition(lon_sign)

    # Check that unsigned latitude and unsigned longitude are numeric
    try:
        ulat = float(str_ulat)
    except ValueError:
        if verbose:
            print(f'Error: "{coord_str}" does not contain a numeric latitude',
                  file=sys.stderr)
        raise ValueError(str)
    try:
        ulon = float(str_ulon)
    except ValueError:
        if verbose:
            print(f'Error: "{coord_str}" does not contain a numeric longitude',
                  file=sys.stderr)
        raise ValueError(str)

    # Check that latitude/longitude fall within legal range
    # Latitude in [-90, +90], Longitude in [-180, 180]
    # So unsigned latitude in [0, 90]
    # And unsigned longitude in [0, 180]
    if ulat < 0 or ulat > 90:
        if verbose:
            print(f'Error: "{coord_str}" contains an invalid latitude',
                  file=sys.stderr)
        raise ValueError(str)
    if ulon < 0 or ulon > 180:
        if verbose:
            print(f'Error: "{coord_str}" contains an invalid longitude',
                  file=sys.stderr)
        raise ValueError(str)

    result = (f'{lat_sign}{str_ulat}', f'{lon_sign}{str_ulon}')
    return result
