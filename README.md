# Riiid! Answer Correctness Prediction solution

This is the 3rd place solution source code to [Kaggle's Riiid! Answer Correctness Prediction competition](https://www.kaggle.com/c/riiid-test-answer-prediction/overview). For a brief write-up and comments please check the [discussion topic on Kaggle](https://www.kaggle.com/c/riiid-test-answer-prediction/discussion/209585).

The solution will be presented at the [35th AAAI Conference on Artificial Intelligence (2021)](https://sites.google.com/view/tipce-2021/home).

# Steps to reproduce

## Used hardware

* Threadripper 1950x + 256 GiB RAM + 6 x RTX 3090 GPUs computer
* Ryzen 9 3950x + 64 GiB RAM + 1 x RTX 3090 GPU computer

## Env setup

Clone this repo and create the `input` directory:

```
git clone https://github.com/jamarju/riiid-acp-pub
mkdir input
```

## Downloading the dataset

1. Make sure you setup a `~/.kaggle/kaggle.json` file that contains the
   credentials that are needed to connect to kaggle. You can create and
   download this from Kaggle by clicking on your user profile directory and
   selecting Account and clicking on `Create New API Token` button which will
   download a `kaggle.json` file to your machine. Make sure you copy it to
   `~/.kaggle/kaggle.json`
1. Once you have the file setup on the machine, you'll need to download the 
   data files for the competition:

   `kaggle competitions download -c riiid-test-answer-prediction`

   The files are quite large - 1.29GB
1. Unzip them and copy them into Azure Storage

ASIDE: I wonder how cheap it would be to use R2 to store these datafiles?

Unzip the dataset into `input` or just copy over the required files:

* `train.csv`
* `lectures.csv`
* `questions.csv`

Alternatively, you can just create a symlink from your dataset path to `input`:

```
ln -s /your/dataset/path input
```

Install conda env and run jupyter:

```
conda env create -f env/env.yaml
conda activate riiid-acp
jupyter notebook --ip 0.0.0.0 --no-browser --NotebookApp.iopub_msg_rate_limit=10000000000
```

## Run notebooks

Run `01_pre.ipynb` to preprocess data. A minimum 128 GiB RAM is required (a swapfile **is** required if your computer has less than 128 GiB of RAM). This will generate the following pkl files in `input/`

* `input/data_v210101b.pkl`
* `input/meta_v210101b.pkl`

Run `02_train.ipynb` to train the model. The default parameters will produce an AUROC score of 0.812 using 2.5% holdout validation users.

The script supports distributed training on multi-GPU setups. See the instructions at the beginning of the notebook for the exact steps.

Additionally more models can be trained and later ensembled changing the number of encoder/decoder layers, heads, transformer activation, dropout, T-Fixup initialization and optimizer without further changes to the code by simply changing `main`'s default parameters. Output:

* `models/best210105.pth`

Run `03_pre_sub.ipynb` to prepare data for submission. This will cut down user's historic data to the last 500 interactions. Outputs:

* `input/data_500_last_interactions_v210101b.pkl`
* `input/data_attempt_num_v210101b.npy`
* `input/data_attempts_correct_v210101b.npy`

Run `04_pre_validation_set.ipynb` to generate a validation split off of `train.csv` in a format suitable for the inference script (similar to `example_test.csv`). Outputs:

* `input/validation_x_0.025.csv`
* `input/validation_y_0.025.csv`
* `input/validation_submission_0.025.csv`

Copy or hard-link the trained models and the following files into `kaggle_dataset/root/resources`:

```
ln input/data_500_last_interactions_v210101b.pkl kaggle_dataset/root/resources
ln input/data_attempt_num_v210101b.npy kaggle_dataset/root/resources
ln input/data_attempts_correct_v210101b.npy kaggle_dataset/root/resources
ln input/meta_v210101b.pkl kaggle_dataset/root/resources
```

For convenience the following two pre-trained models are provided in `kaggle/root/resources`:

* `210105_0.812154_gelu_e4d4_ep30.pth`
* `210105_0.812534_relu_e3e3.pth`

At this point, `ls -l kaggle_dataset/root/resources` should look like this:

```
-rw-rw-r-- 1 javi javi   79921941 Jan 15 23:06 210105_0.812154_gelu_e4d4_ep30.pth
-rw-rw-r-- 1 javi javi   65210849 Jan 15 23:06 210105_0.812534_relu_e3e3.pth
-rw-rw-r-- 2 javi javi 6811424004 Jan 15 22:54 data_500_last_interactions_v210101b.pkl
-rw-rw-r-- 2 javi javi 6085350128 Jan 15 22:54 data_attempt_num_v210101b.npy
-rw-rw-r-- 2 javi javi 6085350128 Jan 15 22:54 data_attempts_correct_v210101b.npy
-rw-rw-r-- 2 javi javi    1953960 Jan 11 11:12 meta_v210101b.pkl
```

Build the resources dataset:

```
cd kaggle_dataset
make
```

Run `05_inference.ipynb`.

If you trained your own models, set the `H1` and `H2` dicts to the appropriate training hyperparams.

The default inference notebook will attempt to ensemble up to two models with dynamic fallback to single model inference in order to fulfill the allocated time budget (8.75h by default).

It should produce an AUROC=0.816 on the default 0.025 user holdout validation set. Sample output:

```
10000it [6:32:02,  2.35s/it, model 1=2482136, model 1+2=2482075, eta=6.581/8.726, auroc (pub)=0.816131, auroc (pvt)=0.816148]
```

The script will also produce a `submission.csv` file with predictions in the same format as `example_sample_submission.csv`.

Alternatively, you can convert the notebook into a raw .py script that can be launched from the command line instead of jupyter's ipython interpreter. The execution should run faster and use less RAM this way. See instructions in the notebook.

# Thanks to...

* Kaggle and Riiid for organizing this challenging competition
* [@wuwenmin](https://www.kaggle.com/wuwenmin) for his [fast ROC AUC calculation routine](https://www.kaggle.com/c/riiid-test-answer-prediction/discussion/208031)

