import sys
from tabulate import tabulate

def ExtractData(inFile):
    found = 0
    required_data = []
    with open(inFile) as freader:
        for line in freader:
            if line[0] == ">":
                found = 0

            if found == 1:
                required_data += [line.strip()]

            if "Sequences producing significant alignments:" in line:
                found = 1

    return required_data

# INPUT: filtered_data
# OUTPUT: Unique identifiers of sequences with hits
#         Data sorted in the order of blast score
def SortData(filtered_data):
    id_to_vals = {}
    for line in filtered_data:
        if len(line.strip()) == 0:
            continue
        eles = line.strip().split()
        id = eles[0]
        name = " ".join(eles[1:-2])
        score = float(eles[-2])
        evalue = float(eles[-1])
        if id not in id_to_vals or float(score) > id_to_vals[id][1]:
            id_to_vals[id] = (name, score, evalue)

    sorted_data = sorted(id_to_vals.items(), key=lambda x: -x[1][1])
    return sorted_data

def PrettyPrint(outFile, sorted_data):
    with open(outFile, "w") as f:
        print_table = []
        for line in sorted_data:
            print_table += [[line[0], line[1][0], str(line[1][1]), str(line[1][2])]]

        print >> f, tabulate(print_table, headers=['ID', 'NAME', 'SCORE', 'EVALUE'])


if __name__ == "__main__":
    inFile = sys.argv[1]
    outFile = sys.argv[2]
    filtered_data = ExtractData(inFile)
    sorted_data = SortData(filtered_data)
    PrettyPrint(outFile, sorted_data)
