// Configuration for the CONLL model from AllenAI, modified slightly
// https://github.com/allenai/allennlp/issues/4273
// and switched to BERT features
// also see https://github.com/allenai/allennlp/issues/5131 for how long sequences are handled
{
  "random_seed": std.extVar("RANDOM_SEED"),
  "numpy_seed": std.extVar("RANDOM_SEED"),
  "pytorch_seed": std.extVar("RANDOM_SEED"),
  "dataset_reader": {
    "type": "weak_label",
    "token_indexers": {
      "bert": {
        "type": "pretrained_transformer_mismatched",
        "model_name": "allenai/scibert_scivocab_uncased",
        "max_length": 512
      },
      "token_characters": {
        "type": "characters",
        "min_padding_length": 3
      },
    },
  },
  "train_data_path": std.extVar("TRAIN_PATH"),
  "validation_data_path":  std.extVar("DEV_PATH"),
  "test_data_path": std.extVar("TEST_PATH"),
  "evaluate_on_test": true,
  "model": {
    "type": "wiser_crf_tagger",
    "label_encoding": "IOB1",
    "dropout": 0.5,
    "include_start_end_transitions": true,
    "text_field_embedder": {
      "token_embedders": {
        "bert": {
          "type": "pretrained_transformer_mismatched",
          "model_name": "allenai/scibert_scivocab_uncased",
          "max_length": 512
        },
        "token_characters": {
            "type": "character_encoding",
            "embedding": {
            "embedding_dim": 16,
            "vocab_namespace": "token_characters"
            },
            "encoder": {
            "type": "cnn",
            "embedding_dim": 16,
            "num_filters": 128,
            "ngram_filter_sizes": [3],
            "conv_layer_activation": "relu"
            }
        }
      }
    },
    "encoder": {
      "type": "lstm",
      "input_size": 768 + 128,
      "hidden_size": 200,
      "num_layers": 2,
      "dropout": 0.5,
      "bidirectional": true
    },
    "regularizer": {
            "regexes": [
                [
                    "scalar_parameters",
                    {
                        "alpha": 0.1,
                        "type": "l2"
                    }
                ]
            ]
        },
    "use_tags": std.extVar("USE_TAGS")
  },
  "data_loader": {
    "batch_size": 8
  },
  "trainer": {
    "optimizer": {
        "type": "adam",
        "lr": 0.001
    },
    "validation_metric": "+f1-measure-overall",
    "num_serialized_models_to_keep": 3,
    "num_epochs": 75,
    "grad_norm": 5.0,
    "patience": 25,
    "cuda_device": -1,
  }
}