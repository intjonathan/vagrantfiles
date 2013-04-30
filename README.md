#vagrantfiles
- - - 

A repository for tracking

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

</pre>