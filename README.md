# Integration

Purpose of the project is to prepare working integration between [GitHub](https://github.com), [Travis-CI](https://travis-ci.org), 
[Maven](https://maven.apache.org/) and [The Central Repository](http://central.sonatype.org/)*.

[*] Central Repository deployment work still in progress 

## How does it work?

Every commit to the project fires Travis CI regular build (see **do_regular_build()** function 
in [.travis/build.sh](https://github.com/incogni7o/integration/blob/master/.travis/build.sh) file).

In case commit message has the format "Release XYZ" where XYZ is equal to the 
[.travis/release.properties](https://github.com/incogni7o/integration/blob/master/.travis/release.properties) 
releaseVersion property, the release build is fired (see **do_release()** function in 
[.travis/build.sh](https://github.com/incogni7o/integration/blob/master/.travis/build.sh) file). 

# Setup

## Create SSH Keys
    
    #ssh-keygen -t rsa -b 4096 -C "yourFunctionalGithubUserEmail@example.com"
 
 File name for the key should be set to "id_rsa".
 No passphrase should be set for the keys.

## GitHub

- create project repository
- create functional user 
- grant write permission for the repository to the user 
- set SSH Public Key (content fo id_rsa.pub) for the user https://github.com/{username}/{repository}/settings
         
## Travis CI

- set the following hidden environment variables https://travis-ci.org/{username}/{repository}/settings
    - **GITHUB_USERNAME** - name of the technical user (can be anything)
    - **GITHUB_EMAIL** - email of the technical user (can be anything)
    - **SSH_SECRET_KEYS** - base64 encoded SSH Private Key 
    
            #cat id_rsa | base64 -w 0 > id_rsa.b64
  