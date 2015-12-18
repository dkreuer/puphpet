class puphpet_redis (
  $redis,
  $apache,
  $nginx,
  $php
) {

  if array_true($apache, 'install') or array_true($nginx, 'install') {
    $webserver_restart = true
  } else {
    $webserver_restart = false
  }

  create_resources('class', { 'redis' => $redis['settings'] })

  if array_true($php, 'install') and ! defined(Puphpet::Php::Pecl['redis']) {
    if $::osfamily == 'debian'
      and $puphpet::php::settings::version in ['54', '5.4']
    {
      puphpet::php::pecl { 'redis':
        service_autorestart => $webserver_restart,
        require             => Class['redis']
      }

      puphpet::php::ini { 'REDIS/extension':
        entry       => "REDIS/extension",
        value       => 'redis.so',
        php_version => '5.4',
        webserver   => $puphpet::php::settings::service,
        notify      => Service[$puphpet::php::settings::service],
      }
    }
  }

}
