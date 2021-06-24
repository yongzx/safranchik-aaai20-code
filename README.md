# README

## Differences in different WISER Version for NCBI-Disease

Older WISER uses `allennlp==0.8.4` and `spacy==2.1.9`. Newer WISER uses `allennlp==2.5.0` and `spacy==3.0.0`.

### Tokenization
> Does `spacy==2.1.9 -> spacy==3.0.6` make any difference in tokenizing the documents?

Yes, but it does NOT impact generative or discriminative models. All of differences (5 instances out of 790) involves tokenization of the character "/". For instance

- In previous `wiser`, "human Na+/glucose cotransporter" is split into `[human, Na, +, /, glucose, cotransporter]`.
- In new `wiser`, "human Na+/glucose cotransporter" is split into `[human, Na, +, /glucose, cotransporter]`.


### LFs
```
😕 Matching Analysis of LFs: ======
[Labeling Function] CoreDictionaryUncased: 100.00 %
[Labeling Function] CoreDictionaryExact: 100.00 %
[Labeling Function] CancerLike: 100.00 %
[Labeling Function] CommonSuffixes: 99.36 %
[Labeling Function] Deficiency: 94.14 %
[Labeling Function] Disorder: 97.07 %
[Labeling Function] Lesion: 99.62 %
[Labeling Function] Syndrome: 97.20 %
[Labeling Function] BodyTerms: 99.87 %
[Labeling Function] StopWords: 76.31 %
[Labeling Function] Punctuation: 100.00 %
[Linking Rule] PossessivePhrase: 100.00 %
[Linking Rule] ElmoLinkingRule: 100.00 %
[Linking Rule] HyphenatedPhrase: 100.00 %
[Linking Rule] HyphenatedPhrase: 100.00 %
[Linking Rule] CommonBigram: 100.00 %
[Linking Rule] ExtractedPhrase: 100.00 %
```

(1) **CommonSuffixes** (👍): New `wiser` does an even better job at identifying plural suffixes because of better lemmatization. For instance, one of the disease suffixes is "-emia", and the new `wiser` can identify "leukemias" (but not the older `wiser`).

---

(2) **Deficiency**, **Disorder**, **Lesion**, **Syndrome**, **BodyTerms** (?): These LFs use dependency relation tags, particularly "compound" tag, assigned by `spacy` dependency parser. However, even though we use the same trained model `en_core_web_sm`, the versions differ: the older `wiser` uses version 2.1.0 whereas the newer `wiser` uses version 3.0.0. Their dependency parsing accuracies differ too (see "las" or "dep_las" in the following links) : [version 2.1.0](https://github.com/explosion/spacy-models/commit/8e402718f565d115a51b25c91a402139f71546e6) vs [version 3.0.0](https://github.com/explosion/spacy-models/commit/98dbe8238120bb079d318fadd8f924992d2569c4). 

In other words, because the dependency relation tags can be different with the newer dependency parser. That is, some noun dependents originally tagged with "compound" tag are now assigned with other tags such as "amod" (adjectival modifier), or vice versa. 

> Why don't we use the old version of `en_core_web_sm`?

The main reason is that we would like to use `SpaCy>=3.0.0`, which is incompatible with the older version of `en_core_web_sm` used in old `wiser`. Doing so would return `OSError: [E053] Could not read config.cfg` (see [reason](https://github.com/explosion/spaCy/issues/7453)).

---

(3) **StopWords** (👍): New `wiser` does an even better job at recognizing stop words. Evaluation is done on the tokens that are assigned different tags by two different versions of `wiser`. 

- new `wiser` identifies 197 stopwords that are assigned ABS by old `wiser`, whereas old `wiser` identifies 97 stopwords that are assigned ABS by new `wiser`. 
- Here's the count of tokens where new `wiser` identify as stopwords but not the old `wiser`: `{'its': 111, 'A': 49, 'WAS': 20, 'Its': 4, 'I': 4, 'AS': 3, 'WHO': 2, 'Am': 1}`
- Here's the other way round: `{'A': 73, 'i': 8, 'I': 7, 'having': 3, 'NO': 2, 'AS': 2, 'Am': 1, 'WHO': 1}`

Same token (such as "A") can be labeled differently because of letter casing during lemmatization. For instance, the newer `wiser` would not convert the capital letters of "G" and "A" in the phrase *"splice-site mutation [IVS14+1G>A)]"* into lowercase, but the older counterpart would. Therefore, the older `wiser` would (miscorrectly) treat the lowercase "a" as a stopword.



