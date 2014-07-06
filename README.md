[![Stories in Ready](https://badge.waffle.io/project-douglas/eris.png?label=ready&title=Ready)](https://waffle.io/project-douglas/eris)
## Introduction

`Eris` is a platform on which decentralized applications may be built. At its core, what Eris seeks to do is to revisit the current state of how consumer applications are developed. Eris was designed as an attempt to provide a framework for development of applications which leverage web technologies, but *without servers*. This is the fundamental, driving design imperative of what Eris is seeking to achieve. We are building a framework which allows developers to build serverless integrated applications using technologies they are already familiar with.

Using Eris is just as easy as using a web application!

![Eris Screenshot](https://raw.githubusercontent.com/project-douglas/eris/master/docs/Sample-Screenshot.png)

### Huh?

Yes. We mean it.

### How?

We have taken a look at how modern web applications are designed and built. Traditionally these have utilized a MVC architecture where a database and language-specific wrapper for that database are used to provide the model component, a different set of language specific modules are used as the controller component, and then finally html, css, and javascript provide the view components. Indeed, most readers on this site will not need a lecture on MVC tech. However, what we asked is how would one design an application framework if one were purposefully trying to do away with central points of failure (which could be DDoS'ed or otherwise attacked, and require significant resources for application developers to maintain). Eris is what we came up with.

Eris operates using two primary components to provide the functionality traditionally found in the model and controller components of modern application, one of which these components operates on a blockchain; the other of which operates in clients which users run on their computers (or, preferably in virtual machines or docker images). The blockchain component is comprised of a series of databases (which provide a portion of the traditional model functionality) and actors (in Eris language these are called ByLaws and they provide a portion of the traditional controller functionality). The offchain component is comprised of a cache of peer-to-peer distributed file blobs (which provide a portion of the traditional model functionality) and actors (which are preformulated API calls that the view component can easily call). The view component is no different than any other view component of a modern web application.

### Why?

There are numerous benefits in attempting to provide a framework for application developers to build distributed applications. First, it is cheaper for application developers because the users will provide the content distribution network. In addition because Eris is built to run on localhost or in a docker image or vm on a user's computer (or on a self-owned cloud droplet) there are limited server costs. Servers, which provide a central point of failure provide difficulties not only for application developers which must harden against DDos attacks and innumerable other attack vectors, but also because users are increasingly skeptical of centralized data silos which retain innumerable pieces of information regarding the state of their affairs.

## Right, So How Does This Work

Fundamentally what is happening is that there is a set of smart contracts which are designed to run (currently at least) on an Ethereum blockchain. These contracts are split into two types. The first type of contracts are database contracts which predominantly store information much how a relational database does. The second type of contracts are ByLaw contracts which provide the blockchain controller functionality. The database contracts within the Eris platform are hardened against attacks by responding only to ByLaws and then only when ByLaws make structured API calls to the databases in particular ways. And then... only if the ByLaws or other requester has permission to take a certain action.

Off chain is a client (currently built in Ruby but easily portable to other languages) which provides the CDN component of the network. This component is called c3D for contract controlled content dissemination. It does what it says, it distributes and disseminates content based on the terms of the database contracts. Predominantly what it does is it wraps content blobs into files, throws them into a torrent client, and then submits the minimum required information to the Ethereum system of contracts. When other clients read the Ethereum blockchain and see additions to contracts which they are subscribed to, those clients will then decode the additional information. If that client does not have the file blobs of a contract which it subscribes to, then it will add those to the torrent client for retrieval.

Finally this package is wrapped up in a small API and view component. Together this allows us to build a Reddit without servers. Which is, as of this v 0.1 release what Eris fundamentally is.

## Cool. How Do I Play With It?

### Easy Install Method (Requires Trust)

To run the easy install method, first download and install Virtual Box.

Then, throw this magnet link in your torrent client: magnet:?xt=urn:btih:05c402749fb155c9b41fd386791ec187d237e001&dn=Project%20Douglas.ova

When the torrent finishes (please seed!), then import the application into your virtual box.

After that you can SSH into the virtual box using:

```bash
ssh -p 3022 pd@127.0.0.1
```

Then enter the password of `projectdouglas`. After that then you will do the following commands:

```bash
cd eris
foreman start &disown
exit
```

Then follow the post install instructions below.

### Docker Install Method (No-trust)

Install [Docker](https://docker.io) from their docs for [Ubuntu](https://docs.docker.com/installation/ubuntulinux/) and [OS X](https://docs.docker.com/installation/mac/).

OSX users should run following script before running eris project
```
curl -O https://raw.githubusercontent.com/project-douglas/eris/master/osx-port-forward.sh && bash osx-port-forward.sh
```

You can use pre-built images from the [Docker Hub](https://hub.docker.com/):
```
docker pull caktux/eris
docker run -i -p 5000:5000 -p 30302:30302 -t caktux/eris
```

Or get Eris and build your own container:
```
git clone https://github.com/project-douglas/eris.git
cd eris/docker
docker build -t eris
```

Run your container:
```
docker run -i -p 5000:5000 -p 30302:30302 -p 51413:51413 -t eris
```

You can edit configurations, address and key in `c3d-config.json` and rebuild your container.


### Harder Install Method (DIY)

As a precursor, you will need Ruby. On linux platforms, you can simply install ruby 2.0 from your friendly package manager. On OSX it comes preinstalled so there's nothing to install.

First you will need an ethereum client. Eris has been tested on the cpp client, but there is no reason to think that it will not work on the go client. You will, however, need the LLL compiler if you wish to deploy your own version of Eris. These clients can be found:

* [Ethereum Go Client](https://github.com/ethereum/go-ethereum)
* [Ethereum CPP Client](https://github.com/ethereum/cpp-ethereum)

Second, you will need a torrent client. Eris has been tested using transmission-daemon and is known to work well. If you were to use another torrent client, you would need to modify the c3D component of Eris before using. Transmission daemon can be installed (depending on your platform) using:

* `sudo apt-get install transmission-daemon`
* `brew install transmission`

Third, you will need to clone this repo and run the install sequence:

* `git clone https://github.com/project-douglas/eris.git`
* `bundle install`

One last thing, which is predominantly for linux. When `apt-get` installs transmission it starts up the daemon. C3D will need to run the daemon manually with the config it puts into ~/.epm/settings.json (that is the transmission config file). So you will have to turn it off the first time with `sudo service transmission-daemon stop` and if you want to permanently turn it off (if you want) with `sudo update-rc.d -f transmission-daemon remove`.

After that you are ready to go. Start the server with `foreman start` and you are ready to interact with your own DAO.

## Post Install

Once you have `foreman start` running without errors then in your browser go to: http://localhost:5000 (or... if you are using the Easy Install Method: http://localhost:5005 ). Once you are there you will see something like this:

![Eris No DOUG 1](https://raw.githubusercontent.com/project-douglas/eris/master/docs/Eris-NoDoug1.png)

Click the MY DAO Button and you will see something like this:

![Eris No DOUG 2](https://raw.githubusercontent.com/project-douglas/eris/master/docs/Eris-NoDoug2.png)

Enter a DOUG address and you are all set.

In the very near future we will have a `Gain Membership with this DAO` button but we currently are still building that method

### But Wait, I Don't Have a DAO.

Funny you should say that, because we have that part also under control. Before starting the server with the above command, you will want to Deploy your very own DAO. Eris depends on the `EPM` gem (Ethereum Package Manager). EPM is built to provide a very simple interface for deploying series of contracts. So just type `bundle exec epm deploy ./contracts/ERIS.package-definition` and your DOUG will deploy. If you run a headed client (which is advised -- just use a different port in your config file) then you can watch your very own DAO deploy before your eyes.

**Note Aleth** does not work with JSON RPC which EPM relies upon to deploy so if you wish to use the CPP client then you will need to run both a headed and headless client. Just make sure to change in your `~/.epm/epm-rpc.json` and `~/.epm/c3d-config.json` config files the directory and peer ports which the headless server runs on.

Once you have a DAO, then run `foreman start`. After that in any web browser go to localhost:5000 and enjoy playing with your DAO!!!!

### Some Commonly Encountered Problems

As of this writing you will not be able to run Eris on the main Ethereum Test Net. The way the Ethereum Virtual Machine has been designed allows for a dynamic amount of gas to be used within each block. Slowly this expands and reduces as prior blocks are heavily used or are not used. Because the current test net is mostly being used (right now) for working on the mining algorithm there are many unused blocks. The result of this is that the gas limit per block has been reduced so low that DOUG the very first contract, and almost all of the rest of the contracts required to run Eris cannot be deployed. As of this writing, DOUG needs about 14000 gas to deploy and the current minimum gas amount per block is around 10000 so even using the entire gas in a block will not allow you to deploy one contract per block.

> Solution 1. This is a known issue for the Ethereum team, and we are sure they have a fix in mind so one solution is to wait until that is fixed.

> Solution 2. If you want, you can use your own test net which will not present you with such an error. Alternatively, you can build our [reference client](https://github.com/project-douglas/cpp-ethereum) or simply join the PD testnet on 173.246.105.207:30303. Since we do a lot of deploys and transactions per block you should not face that error on our net. Be advised our test net gets reverted a lot. So be wary.

## Contributing

Fork.
Hack.
Pull Request.

## License

Decentralised Autonomous Organisations, or DAOs, are new and legally untested platforms. Their use may give rise to criminal liability in certain jurisdictions where, e.g., data encryption is banned. In more liberal jurisdictions, the use of such software in applications which are tightly regulated by consumer protection legislation - for example, platforms aimed at offerings of debt, equity, or other forms of investment contract, consumer credit, or money transfer - may apply. Finally, structuring the relationship between an Eris userbase and an entity which deploys the Eris platform will give rise to significant liabilities on the part of the platform operator/owner and its directors and may expose its userbase to economic or other types of harm.

**It is imperative that prior to deploying the software proper and thorough independent legal advice and specialist coding advice is obtained from qualified professionals.**

Eris is provided "as is", without warranty or representation of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall Project Ðouglas and each and any member of the Project Ðouglas Dev Team be liable to you or any other person for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.

See `LICENSE.md`.

In other words, don't be a jerk.
