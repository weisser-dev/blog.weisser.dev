---
layout: post
title:  "Create a custom *.onion URL with Shallot"
---

# Create a custom *.onion URL with Shallot

It is very simple to create your own domain for the Tor network.
-> If you don't know how to install the Tor service and host a site there, read the following article: [tor-hidden-service-nginx](/tor-hidden-service-nginx)

## Step 1 - Download Shallot
Change to your opt folder
``` cd /opt ``` 
Now there are two ways to get Shallot. 
### Via Git
``` git clone https://github.com/katmagic/Shallot.git ```
### Via Browser
``` curl https://github.com/katmagic/Shallot/archive/master.zip ```

## Step 2 - Install Shallot
Installing Shallot is also very easy, just type the following commands in your terminal: 
``` 
cd /opt/Shallot/
./configure && make
./shallot 
```

## Step 3 - Generate your *.onion URL
To generate a *. onion url now, we only have to execute shallot and give our desired url as parameter. You should always keep in mind the times for the url generation, these are linked on the [github](https://github.com/katmagic/Shallot) page of the project.

```
$  ./shallot ^white
------------------------------------------------------------------
Found matching domain after 44181553 tries: whitejqzenjmyya7.onion
------------------------------------------------------------------
-----BEGIN RSA PRIVATE KEY-----
MIICXgIBAAKBgQDO7hI7U6ZuH/4Has0TzMAoH+n36TvHyjdSLKrzU90StlrkoQFf
w6ZZHXFYW5R7M9J43M+L03bJ8mOlUUTby4NqkJ39hKYuY/fRKFmNTEzbCiR3Hq/P
HjfXvd9CeZQFA8JfILpWfQNTuZcMMDGS0a/leuknEab0EzDq6lEBsHXPWwIEAWJg
iwKBgBxsOPzixRFXXZxl1nEbQHVPQCOh/bBNeUiY78TkHHbFDJatww2/Bu88JYEb
hAfUV61xKNcPu0CS/Lu0JSxBo60f9Q7tUv10q3bl9cz/X/3Beb5fW9sCOFVEnCH8
Zo66AZOX219YsrCV0MU+82KGH8ckOvIhxPNMgyIUB9DzBJATAkEA9ODPaAsUMQcu
dliegijag9q7tQCAuvSsjm/TTsEwCdsuGMIxrfL0FP9w23PbJI6i1JNVRxHZ9BU9
wr39haPE9QJBANhUCeWN8C608S6OmwSRwLrrNZxo75Fwy4Dw8dyfA7Uy9lA9Fyj8
mgyQ5cHCyZ0OpGii57odb7s/i1H4hbcFEQ8CQQCaeV7uQs76EWtm62e8or9Hb9qW
r7Hu3rIpt9+jljIlupZ3SYOSaxVy8kQgP52S+dQj9QLn/H9yc/QbGAu+SdrXAkBA
93cCmDbkHeeoA2u1MPjDC9BHunqVGi4U0NIApwrQEa0xL0RIsqBk4I5JHwyTEOE/
tFKxsc37ty5/E/klFaWNAkEA7sg3tJz5qJ9fN/JXneSPqokqiIkBxNcHzmFccPAY
8H9f55cHwlfJzR1zS7K0dGpOX4J43sjKqViUVSMHwS4QKA==
-----END RSA PRIVATE KEY-----

```
After a matching url has been found, we only have to replace the existing private_key in our Tor directory (/var/lib/tor/example_page) with the new one.
And finally we restart Tor and can now reach our site via the new domain.

## Optional 

Because the generation of larger addresses takes more time. I have written a small shell script which allows us to save all generated urls.
In other words, if I want a URL that starts with "whitecom", I can give one ^white as a parameter - so all created urls start with white. And as soon as I have one that starts with "whitecom" I stop creating urls. This gives me the possibility to generate several suitable domains and to choose the best one at the end, because all private_keys are stored in the /tmp folder.

Here a short example:

    ./addressgenerator.sh ^whi white
    ---------------------------------------------------------------
    Found matching domain after 65819 tries: whitedofszgmqnoq.onion
    ---------------------------------------------------------------
    -----BEGIN RSA PRIVATE KEY-----
    MIICXAIBAAKBgQDEl0aii2Uh2p1S+4LymgvTSE2FxgyBASu7ke3WydBR6PEXwfNh
    /9GMxpOms9TeuHRneHPntie0oBd01fh6Lfk/pSs+BViiqQqfkvIgK6cRYl1nSDaO
    hOzKKwL4/HEFCKD5sav89oGrkZSryV94ipkY7IkdIwwP5a4FugAX0G1VTwIDAwI1
    AoGAAXb0LSOzXXylIBxvfsfFBVeJO6f9O/OmU0nWJA6lPzsoCrHobonLnQZqxokj
    FgYkTJ2M0xjowrXqYsR8DwKoUJTFMCpKqt8rideB/vcbn1HtfqxV6f6CaHd0V8RQ
    gtmZOIm3u7Xzw7uGcbhk681L/I/8m4kZvT4ywZHtqS7LJB0CQQDjiZoX3dMJEIgk
    sAAhCTJYVWTNap2Z7UX2/Nfea6W0ylJj3NvLepoo9pKJoVhYXlpYSY0F5Ln6LYZG
    oDFInUNPAkEA3S6tIgyaMGro8hI8cLIZhbWMv3E3rX4sCWLTzbebWRUUlOKJWyYN
    0zvU6CIhiS30XOZRGmZTyI3KCZW8klJOAQJAFehTbkfRt+nDq6znpMZity1nF4io
    iQ1i6wEBj9vKNkmjoofpXGAehtoEkjJ+b28MQdyQ0gnTRV1i8K1i3n6VjQJBAL7m
    vXSvspX2ZvC00IgJLzJciAuAst7g1l5B0XXgQfLyHVyuepTVjNgwpnnzZkONMxAh
    2QgV5FBet6oiZWrGwh0CQFvPgz6zyR0QFtftvtSwemgDlK7qk+v1nGclZNf6fgJk
    I1hC7rXLmkDesIsIdqPZ5NQV8/HfpEIXWS1AXCrR4B4=
    -----END RSA PRIVATE KEY-----

I have now generated about 5-10 domains which all started with whi. Domains with the beginning of "whit3" and so on could have been there. When the domain finally started with "white" I stopped generating new ones and displayed the appropriate Private_Key.
As a result, I was able to notice a significant reduction in the time taken to generate new domains.

My small script for address generation can be found [here](https://github.com/whit-e/OnionAddressGenerator).
It must be in the same folder as Shallot and you should create a tmp folder there.
