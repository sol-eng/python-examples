import fire
import json
import os
import numpy as np
import tensorflow as tf

import model, sample, encoder


def get_predict_function(
    model_name='117M',
    seed=None,
    nsamples=1,
    batch_size=1,
    length=None,
    temperature=1,
    top_k=0,
    niter=5
):
    """
    Interactively run the model
    :model_name=117M : String, which model to use
    :seed=None : Integer seed for random number generators, fix seed to reproduce
     results
    :nsamples=1 : Number of samples to return total
    :batch_size=1 : Number of batches (only affects speed/memory).  Must divide nsamples.
    :length=None : Number of tokens in generated text, if None (default), is
     determined by model hyperparameters
    :temperature=1 : Float value controlling randomness in boltzmann
     distribution. Lower temperature results in less random completions. As the
     temperature approaches zero, the model will become deterministic and
     repetitive. Higher temperature results in more random completions.
    :top_k=0 : Integer value controlling diversity. 1 means only 1 word is
     considered for each step (token), resulting in deterministic completions,
     while 40 means 40 words are considered at each step. 0 (default) is a
     special setting meaning no restrictions. 40 generally is a good value.
    """
    niter = int(niter)
    length = int(length)
    
    if batch_size is None:
        batch_size = 1
    assert nsamples % batch_size == 0

    enc = encoder.get_encoder(model_name)
    hparams = model.default_hparams()
    with open(os.path.join('models', model_name, 'hparams.json')) as f:
        hparams.override_from_dict(json.load(f))

    if length is None:
        length = hparams.n_ctx // 2
    elif length > hparams.n_ctx:
        raise ValueError("Can't get samples longer than window size: %s" % hparams.n_ctx)
    
    sess = tf.Session()
    context = tf.placeholder(tf.int32, [batch_size, None])
    
    np.random.seed(seed)
    tf.set_random_seed(seed)
    output = sample.sample_sequence(
        hparams=hparams, length=length,
        context=context,
        batch_size=batch_size,
        temperature=temperature, top_k=top_k
    )

    saver = tf.train.Saver()
    ckpt = tf.train.latest_checkpoint(os.path.join('models', model_name))
    saver.restore(sess, ckpt)
    
    def predict(raw_text):
        print("Input text:", raw_text)
        
        for i in range(niter):
          generated = 0
          for _ in range(nsamples // batch_size):
              # This is usually just one loop as nsamples is usually one
              context_tokens = enc.encode(raw_text)
              out = sess.run(output, feed_dict={
                  context: [context_tokens for _ in range(batch_size)]
              })[:, len(context_tokens):]
              for i in range(batch_size):
                  generated += 1
                  text = enc.decode(out[i])
                  raw_text = raw_text + text
              yield text
        
    return predict


def download_if_needed(model):
    """This is a function version of download_model so the code runs in connect
    """
    import os, sys, requests
    from tqdm import tqdm
    subdir = os.path.join('models', model)
    if os.path.exists(subdir):
        print("model exists")
        return
    
    os.makedirs(subdir)
    subdir = subdir.replace('\\','/') # needed for Windows
    
    for filename in ['checkpoint','encoder.json','hparams.json','model.ckpt.data-00000-of-00001', 'model.ckpt.index', 'model.ckpt.meta', 'vocab.bpe']:
    
        r = requests.get("https://storage.googleapis.com/gpt-2/" + subdir + "/" + filename, stream=True)
    
        with open(os.path.join(subdir, filename), 'wb') as f:
            file_size = int(r.headers["content-length"])
            chunk_size = 1000
            with tqdm(ncols=100, desc="Fetching " + filename, total=file_size, unit_scale=True) as pbar:
                # 1k for chunk_size, since Ethernet packet size is around 1500 bytes
                for chunk in r.iter_content(chunk_size=chunk_size):
                    f.write(chunk)
                    pbar.update(chunk_size)


if __name__ == "__main__":
    download_if_needed("345M")
    # predict = get_predict_function("345M", length=40, niter=5)
    # text = "A dragon flew from the sky"
    # for i, text in enumerate(predict(text)):
    #     print("Pget_predict_function(), text)
