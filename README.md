# Blog Stack

Docker stack configuration for highly-available WordPress.

## Components

All you really need is a database, but to make sure WordPress is running at peak efficiency we're shipping multiple, individually containerized components.

**WordPress** itself is running as a container built atop the [official WordPress Docker image](https://hub.docker.com/_/wordpress). Specifically, we're using the image built atop PHP 8.3 using Apache. The `Dockerfile` in this project leverages that image but also adds in the Memcached extension for better object caching.

**Memcached** is used as a fast, lightweight, in-memory object cache to enhance WordPress' performance.

**MySQL** is the backing database for the project.

**Varnish** is reverse proxy that acts as an "application accelerator" to further enhance front-end performance of your WordPress site.

## State Management

For WordPress itself, the largetst container of state is the MySQL database. Within Docker, we're mounting this as a persistent volume to ensure nothing is lost during container reloads or builds.

The WordPress filesystem is also stored in a volume, but is mounted directly from a path on the _host_ to ensure you have full visibility into the code running on your server. This makes managing plugins a bit easier and allows you to manipulate certain things _live_ if necessary.

It also makes backing up your uploads directory a bit easier, too!

## Configuration

Copy the `.env.example` file to `.env` and set your database username and password accordingly. You'll also want to set a root password should the `root` user ever be needed.

Ensure you map the WordPress data path to an appropriate location on your host filesystem as that's where all of the PHP files and image uploads for your blog will live.

## Recommended Plugins

The stack itself will install vanilla WordPress. Further configuring your environment with themes and plugins is up to you. However, to get the best use of the system, you'll want to install the following:

### [Batcache](https://wordpress.org/plugins/batcache/)

Batcache is a full-page cache for the front-end of your site. Paired with an in-memory object cache and a reverse proxy like Varnish it makes your site _lightning_ quick.

Note that merely installing the plugin isn't a typical install. You'll need to move `advanced-cache.php` to your `/wp-content` directory and then add the following like to your `wp-config.php` file:

```
define( 'WP_CACHE', true );
```

You can then place the `batcache.php` file in your `/wp-content/plugins` directory to make the Batcache Manager plugin (which helps improve cache integration) available for activation.

### [Jetpack](https://wordpress.org/plugins/jetpack/)

This is an entirely optional (and somewhat opinionated) recommendation. However, Jetpack avails the entire WordPress.com CDN to your site. This means media uploads will be cached at and delivered by a separate edge server rather than your Docker installation.

If you're running a beefy server, it's likely not necessary. If your blog lives on a Raspberry Pi or somewhere else in your home lab, offloading media serving to a larger CDN will save you a headache.

### [Proxy Cache Purge](https://wordpress.org/plugins/varnish-http-purge/)

This plugin helps manage your Varnish cache. Install it, then navigate to the settings page within your WordPress Admin. You'll need to set the "custom IP" to `varnish` so the plugin knows how to talk to the cache.

### [wordpress-pecl-memcached-object-cache](https://github.com/tollmanz/wordpress-pecl-memcached-object-cache)

This isn't a traditional plugin. Merely place the `object-cache.php` file from the project into your `/wp-content` folder to add the plugin. To actually enable it, add the following code to your `wp-config.php` file (prior to the `require_once ABSPATH . 'wp-settings.php';` line):

```
global $memcached_servers;
$memcached_servers = array(
    array(
        'memcache', // Memcached server IP address
        11211       // Memcached server port
    )
);
```