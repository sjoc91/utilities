import re
import argparse

def round_gcode(input_file, output_file, decimal_places):
    try:
        with open(input_file, 'r') as file:
            gcode_lines = file.readlines()

        rounded_lines = []
        for line in gcode_lines:
            # Use regex to find numbers in the line
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
    except Exception as e:
        print(f"An error occurred: {e}")

def main():
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
        default="output_gcode.gnc",
        help="Output file name (default: output_gcode.txt)."
    )

    args = parser.parse_args()
    round_gcode(args.file, args.output, args.decimal_places)

if __name__ == "__main__":
    main()
