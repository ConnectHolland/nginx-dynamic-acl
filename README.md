# nginx-dynamic-acl
Dynamic ACL for Nginx written in Lua.

## Installation

### Installing Nginx on Ubuntu / Debian
The following command will install Nginx with extra modules, including the Embedded Lua module:
```
$ sudo apt-get install nginx-extras
```

### Installing nginx-dynamic-acl
Clone this repository to a directory of your chosing:
```
$ git clone -b <branch or version> --single-branch https://github.com/ConnectHolland/nginx-dynamic-acl.git <nginx-dynamic-acl installation directory>
```

Add the package path to the Nginx server configuration within the `http` context:
```
lua_package_path '<nginx-dynamic-acl installation directory>/src/?.lua;;';
```


## Usage
Before configuring the nginx-dynamic-acl module you require to have [basic authentication](http://nginx.org/en/docs/http/ngx_http_auth_basic_module.html) already configured for a server configuration.

### Create an authorizations JSON file
The ACL configuration is stored in a JSON file with 2 root keys `userGroups` and `groupAuthorizations`.
The `userGroups` key contains the mapping of a user to a group within the `groupAuthorizations`.
The `groupAuthorizations` key contains the name of the group and a set of allowed Regex paths with their allowed request methods.

``` json
{
    "userGroups": {
        "john": "user"
    },
    "groupAuthorizations": {
        "user": {
            "^/$": ["GET"],
        }
    }
}
```

In the above example you see a user named 'John' configured to be member of the group named 'user'.
This group is allowed to sent a get request to the root of a configured website.

### Configure nginx-dynamic-acl in a specific server configuration
The following examples demonstrate how the nginx-dynamic-acl Lua module should be configured for different versions of Embedded Lua:

##### Embedded Lua versions greater than 0.9.16

```
server {
    # ...

    location / {
        auth_basic              "Protected realm";
        auth_basic_user_file    <location of your passwords file>;

        access_by_lua_block {
            require("dynamic_acl").authorize("<location to your authorizations JSON file>")
        };
    }

    # ...
}
```


##### Embedded Lua versions lower than 0.9.17

```
server {
    # ...

    location / {
        auth_basic              "Protected realm";
        auth_basic_user_file    <location of your passwords file>;

        access_by_lua '
            require("dynamic_acl").authorize("<location to your authorizations JSON file>")
        ';
    }

    # ...
}
```


## Credits and acknowledgements
* Created by [Niels Nijens](http://github.com/niels-nijens).
* Inspired by [Playing HTTP Tricks with Nginx](https://www.elastic.co/blog/playing-http-tricks-nginx) by [Elastic](https://github.com/elastic).
* Uses [JSON4Lua](http://json.luaforge.net/) by Craig Mason-Jones to decode the JSON authorization configuration.


## License
This Lua module is licensed under the MIT License. Please see the [LICENSE file](LICENSE.md) for details.
