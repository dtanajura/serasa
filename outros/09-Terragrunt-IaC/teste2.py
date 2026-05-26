def parse_terragrunt_file(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    result = []
    current_section = None
    inside_section = False

    for line in lines:
        stripped_line = line.strip()
        
        # Skip empty lines
        if not stripped_line:
            continue
        
        # Check for section headers
        if stripped_line.endswith('{'):
            current_section = stripped_line[:-1].strip()
            inside_section = True
            continue
        
        # Check for section end
        if stripped_line == '}':
            inside_section = False
            continue
        
        # Process key-value pairs inside a section
        if inside_section:
            parts = line.split('=', 1)
            if len(parts) == 2:
                key = parts[0].strip()
                value = parts[1].strip()
                indentation = len(line) - len(line.lstrip())
                result.append((current_section, indentation, key, value))
    
    return result

def write_terragrunt_file(parsed_data, output_file_path):
    with open(output_file_path, 'w') as file:
        current_section = None

        for section, indentation, key, value in parsed_data:
            if section != current_section:
                if current_section is not None:
                    file.write('}\n\n')
                file.write(f'{section} {{\n')
                current_section = section

            indent_spaces = ' ' * indentation
            file.write(f'{indent_spaces}{key} = {value}\n')

        if current_section is not None:
            file.write('}\n')


if __name__ == "__main__":
    file_path = 'terragrunt.hcl'
    parsed_data = parse_terragrunt_file(file_path)
    for item in parsed_data:
        print(item)
    write_terragrunt_file(parsed_data, "teste.hcl")