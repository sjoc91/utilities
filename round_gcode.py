import re
import argparse
import os


def round_gcode_numbers(input_file, output_file, decimal_places):
    """
    Processes a G-code file to round all floating-point numbers to 
    the specified number of decimal places.

    Args:
        input_file (str): Path to the input G-code file.
        output_file (str): Path to save the rounded G-code output file.
        decimal_places (int): Number of decimal places to round to.

    Raises:
        FileNotFoundError: If the input file does not exist.
        Exception: For any other runtime error.
    """
    try:
        with open(input_file, 'r') as file:
            gcode_lines = file.readlines()

        rounded_lines = []
        for line in gcode_lines:
            rounded_line = re.sub(
                r'(-?\d+\.\d+)',
                lambda match: f"{float(match.group()):.{decimal_places}f}",
                line
            )
            rounded_lines.append(rounded_line)

        with open(output_file, 'w') as file:
            file.writelines(rounded_lines)

        print(f"Rounded G-code saved to {output_file}")
    except FileNotFoundError:
        print(f"Error: File {input_file} not found.")
    except Exception as error:
        print(f"An error occurred: {error}")


def generate_default_output_filename(input_file, decimal_places):
    """
    Generates a default output file name based on the input file name 
    and the decimal places.

    Args:
        input_file (str): Path to the input G-code file.
        decimal_places (int): Number of decimal places to round to.

    Returns:
        str: Generated output file name.
    """
    base_name, ext = os.path.splitext(input_file)
    return f"{base_name}_{decimal_places}_decimals{ext}"


def main():
    """
    Parses command-line arguments and processes the G-code file.
    """
    parser = argparse.ArgumentParser(description="Round numbers in G-code commands.")
    parser.add_argument(
        "file",
        type=str,
        help="The G-code file to process."
    )
    parser.add_argument(
        "-d", "--decimal_places",
        type=int,
        default=3,
        help="Number of decimal places to round to (default: 3)."
    )
    parser.add_argument(
        "-o", "--output",
        type=str,
        help="Output file name (default: input file name with decimal places appended)."
    )

    args = parser.parse_args()

    # Generate default output file name if not specified
    output_file = args.output or generate_default_output_filename(
        args.file, args.decimal_places
    )

    round_gcode_numbers(args.file, output_file, args.decimal_places)


if __name__ == "__main__":
    main()
