#!/usr/bin/env python

import spacy

model_dir = "model"

def predict(input):
    nlp = spacy.load(model_dir)
    doc = nlp(input)
    result = (input, doc.cats)
    return result
