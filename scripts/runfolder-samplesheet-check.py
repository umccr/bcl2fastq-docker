import sys
from sample_sheet import SampleSheet

# TODO: write logs rather than simple print statements
sample_sheet = SampleSheet(sys.argv[1])

# first create all index length tuples
index_tuples = set()
for sample in sample_sheet:
    index_length = len(sample.index.replace("N",""))

    if sample.index2:
        index2_length = len(sample.index2.replace("N",""))
    else:
        index2_length = 0

    index_tuples.add((index_length, index2_length))

print(index_tuples)

# then check if we have index combinations we cannot handle
# if there are more than one combination, we abort as a custom sample sheet is required
if len(index_tuples) is not 1:
    print("ERROR: There are multiple index combinations!")
    exit(1)

# there is only a single index combination
index_tuple = index_tuples.pop()
# if the second index is 0 we are fine
if index_tuple[1] is 0:
    print("INFO: Second index is missing... all good.")
    exit(0)

if index_tuple[0] is not index_tuple[1]:
    print("ERROR: Indexes with different length")
    exit(1)

print("INFO: Indexes have same length... all good.")
