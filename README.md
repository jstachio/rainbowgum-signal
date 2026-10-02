# rainbowgum-signal

Reopens [Rainbow Gum](https://github.com/jstachio/rainbowgum) outputs when the process
receives a Unix signal, for log rotation with tools like `logrotate`.

On Linux, and in most container deployments, a signal is a simpler alternative to an
HTTP reopen endpoint: no port needs to be opened or secured, and no application code is
needed. When the configured signal arrives, this module calls
`LogOutputRegistry.reopen()`.

## Installation

```xml
<dependency>
  <groupId>io.jstach.rainbowgum</groupId>
  <artifactId>rainbowgum-signal</artifactId>
  <version>VERSION</version>
</dependency>
```

## Enabling

**Depending on this module does not activate it.** Installing a signal handler is an
ambient capability change (any process allowed to signal this one could trigger it), so
it is disabled by default. Enable it with:

```properties
logging.signal.enable=true
```

or programmatically, by passing `new SignalConfigurator().enabled(true)` to
`LogConfig.Builder.configurator(...)`. That call is itself the opt in, independent of
the property.

The signal defaults to `USR1` and can be changed with `logging.signal.name` (or
`SignalConfigurator.signalName(String)`).

## logrotate example

Assuming the application writes its pid to `/var/run/app.pid`:

```
/var/log/app.log
{
  rotate 4
  weekly
  missingok
  notifempty
  compress
  delaycompress
  sharedscripts
  nocreate
  postrotate
    kill -USR1 $(cat /var/run/app.pid) 2>/dev/null || true
  endscript
}
```

For Spring Boot applications, the
[process monitoring support](https://docs.spring.io/spring-boot/reference/actuator/process-monitoring.html)
includes `ApplicationPidFileWriter`, which writes the running application's pid to a
file (`application.pid` by default).

## Windows

There are no POSIX signals on Windows. If the signal cannot be installed, the module
records an error alert and installs nothing instead of failing startup, so it is safe to
leave on the classpath of a cross platform application.

## Building

```
./mvnw clean install
bin/analyze.sh   # checkerframework, errorprone, nullaway
```

See [release.md](release.md) for releasing.
