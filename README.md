A pure Ruby console application that encodes or decodes images in BASE64

 Example usage:
```
        # encode
        encode_image.rb -e --path=/home/username/foobar.png #=> SGVsbG8sIHdvcmxkIQ==
        
        # decode
        encode_image.rb -d -b=SGVsbG8sIHdvcmxkIQ== #=> File has been stored at /home/username/encode_image/foobar.png
```

Optional params:
```
              -e,  --encode        Encode param.
              -p=, --path=         Path to file.
              -d,  --decode        Decode param.
              -b=                  Base64 string.
          Not optional params:
              -f=, --filename=     Filename to create after decoding (test_name.%ext_name% by default).
          Other params:
              -h,  --help          Show this help.
```

I hope you enjoy this app!
