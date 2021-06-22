from pathlib import Path

root = Path("/users/zyong2/data/zyong2/clws/scripts/exp-003/esteban")

import random
import os
import subprocess

def train_discriminative_model(train_data_path, dev_data_path, test_data_path,
                               train_config_path, output_path='output/discriminative/default',
                               cuda_device=-1, use_tags=False, seed=None):

    if seed is None:
        seed = random.randint(0, 10e6)

    os.environ['RANDOM_SEED'] = str(seed)
    os.environ['TRAIN_PATH'] = str(train_data_path)
    os.environ['DEV_PATH'] = str(dev_data_path)
    os.environ['TEST_PATH'] = str(test_data_path)
    # os.environ['CUDA_DEVICE'] = str(cuda_device)
    os.environ['USE_TAGS'] = str(use_tags)

    # try:
    #     output = subprocess.check_output('allennlp train %s -f -s %s --include-package wiser' % (train_config_path, output_path), shell=True)
    # except subprocess.CalledProcessError as e:
    #     output = e.output
    #     print("Error:", output)
    #     assert False

    command = 'allennlp train "%s" -f -s "%s" --include-package wiser' % (train_config_path, output_path)
    print(command)
    os.system(command)
    print("🚀 Success")
    # assert False

dev_file = root / 'dev_data.p'
test_file = root / 'test_data.p'
config_path = root / 'NCBI-Disease_config.jsonnet'


cuda_device = 0
num_iterations = 5
for iteration in range(num_iterations):
    for model in ['mv', 'unweighted', 'nb', 'hmm', 'link_hmm']:

        train_file = root / f'train_data_{model}.p'
        output_path = root / f'discri_{model}_{iteration}'

        output = train_discriminative_model(
            train_data_path=train_file,
            dev_data_path=dev_file,
            test_data_path=test_file,
            train_config_path=config_path,
            output_path=output_path,
            cuda_device=cuda_device)
        print("Done", model, iteration)
        assert False

    train_file = root / f'train_data_mv.p'
    output_path = root / f'discri_supervised_{iteration}'

    output = train_discriminative_model(
        train_data_path=train_file,
        dev_data_path=dev_file,
        test_data_path=test_file,
        train_config_path=config_path,
        output_path=output_path,
        use_tags=True,
        cuda_device=cuda_device)

