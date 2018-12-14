import sys
from os import listdir
from os.path import join

dirname = sys.argv[1]
for filename in listdir(dirname):
    if not filename.endswith(".tsv"):
        continue
    input_name = join(dirname, filename)
    output_name = input_name.rsplit(".")[0] + ".libsvm"
    with open(output_name, 'w') as fout:
        with open(input_name) as f:
            for line in f:
                nums = list(map(float, line.split()))
                features = nums[:4] + nums[5:]
                label = int(nums[4]) >= 998
                fout.write(
                    str(int(label)) + ' ' + \
                    ' '.join(["{}:{}".format(i, v) for i, v in enumerate(features)]) + '\n'
                )