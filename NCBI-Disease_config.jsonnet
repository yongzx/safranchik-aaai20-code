// Configuration for the CONLL model from AllenAI, modified slightly
// https://github.com/allenai/allennlp/issues/4273
// and switched to BERT features
// do_lowercase: see https://github.com/allenai/allennlp/pull/3364
// truncate_long_sequences: see https://github.com/allenai/allennlp/issues/5131 for how long sequences are handled
// train_parameters: see https://github.com/allenai/allennlp/issues/4273 as the older version wouldn't train BERT.
// last_layer_only: in http://docs.allennlp.org/main/api/modules/token_embedders/pretrained_transformer_embedder/ , its default is true, but in
//      allennlp-0.8.4 (refer to allennlp-0.9.0), top_layer_only defaults to false.
// type: "pretrained_transformer_mismatched" because in WeakLabelDatasetReader, we use instance['tokens'], which are strings that are tokenized into words.
//      PretrainedTransformerMismatchedIndexer splits the words into wordpieces and flattens them out.

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
          "max_length": 512,
          "train_parameters": false,
          "last_layer_only": false
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
    "cuda_device": 0,
  }
}