import os
import json
import requests
from PIL import Image
from torchvision import models, transforms
from torch.autograd import Variable

# Set PyTorch model directory
os.environ["TORCH_HOME"] = "./model"

squeeze = models.squeezenet1_1(pretrained=True)
squeeze.eval()

normalize = transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])

preprocess = transforms.Compose(
    [
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        normalize,
    ]
)

with open("labels.json") as f:
    labels_data = json.load(f)

labels = {int(key): value for (key, value) in labels_data.items()}


def classify_image_pytorch(image_path):

    img_pil = Image.open(image_path)
    img_tensor = preprocess(img_pil)
    img_tensor.unsqueeze_(0)
    img_variable = Variable(img_tensor)
    fc_out = squeeze(img_variable)

    top_k = fc_out.data.numpy()[0].argsort()[-5:][::-1]
    results = []
    for prediction in top_k:
        description = labels[prediction]
        score = fc_out.data.numpy()[0][prediction]
        results.append(("%s (score = %.5f)" % (description, score)))

    return results
