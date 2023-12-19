 
import urllib.parse

def decode_url(url_encoded_str):
    return urllib.parse.unquote(url_encoded_str)
 