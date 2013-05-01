#vagrantfiles
------------ 

A repository for tracking just the `Vagrantfile`s in Vagrant projects.

###Special `.gitignore` file

This repo has a special `.gitignore` that makes it only track `Vagrantfile`s in top-level subdirectories:

<pre>
.
├── README.md
├── dam
│   └── Vagrantfile
├── icinga
│   ├── Vagrantfile
│   └── vagrant
├── jira
│   ├── Vagrantfile
│   └── packages
├── nagios
│   ├── Vagrantfile
│   └── packages
├── provisioning
│   └── Vagrantfile
├── puppetdb
│   └── Vagrantfile
└── puppetpassenger
</pre>

In the above folder structure, only the `Vagrantfile` files in the various folders get tracked. `packages` and other folders and files are ignored. There are some exceptions, like `README.md` and `.gitignore` itself.

The complete `.gitignore` file:

<pre>
#Start off by ignoring everything
*
 
#Don't ignore top-level subdirectories (`!` tells git to NOT ignore things that match the pattern after the `!`); we need git to be able to look inside of them so it can....
!*/
 
#...track the Vagrantfiles inside.
!*/Vagrantfile

#Track only this repo's .gitignore so others who pull down the repo won't have to create it manually.
!./.gitignore

#Track only this repo's README.md
!./README.md
</pre>