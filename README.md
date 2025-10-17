# Warden: a monitoring/observability subsystem template
This repo contains a template of a monitoring/observability subsystem based on Grafana/OTEL stack.
It can be used for pretty much any small/medium sized project that has Users and Authorization and exports expected metrics.
Or...just tweak it to your needs!

👉 Initially, developed as a part of my [FastAPI monolith template](https://github.com/Narsonos/fapi_monobase).

Contains:
- Grafana with provisioned datasources and dashboards split onto 3 cathegories (System, API, Domain);
- Prometheus with pre-set rules and alerts; 
- Alertmanager with alerts to Telegram;
- Loki that expects to recieve logs;
- Tempo with OTel-Collector for collecting traces;
- Nginx that serves as reverse proxy;
- A simple github actions deployment .yml file;
- An inject_env.sh script that goes over all .yml|.yaml files and substitutes .env placeholders during deploy with .envs passed in deploy.yml file. That allows to hide sensetive data. Please, take into account that inject_env.sh is not idempotent - it overwrites placeholders with known env vars values.

**Relationships between the services are visualised below:**

![Project architecture](diagram.svg)


## Prometheus config & rules (what's in the repo)
Prometheus rules are defined under services/prometheus/rules. Each file contains recording rules (precomputed metrics) and alerting rules used by Alertmanager.

- services/prometheus/rules/system.yml
  - Recording rules: cpu and per-CPU load (note: cpu temperatures graph needs to be fixed!), RAM load, filesystem free/used/total per mountpoint, disk IO and throughput, network in/out and error/drop rates.
  - Alerts: CpuOver90, RamOver90, DiskSpaceLow, DiskLoadOver90 — thresholds for CPU/RAM/disk health.

- services/prometheus/rules/api.yml
  - Recording rules: RPS, request sizes, latency quantiles and aggregates (p95/p99 by job/endpoint/method), per-target-method latency and 5xx/error ratios.
  - Alerts (group API-alerts): High5xxRate, HighLatencyP95, TooManyInFlightRequests, LargeResponseSize — watch for elevated 5xx, high p95 latency, too many concurrent requests, large responses.

- services/prometheus/rules/domain.yml
  - Recording rules: domain-specific auth metrics.
  - Alerts: LoginsCount (informational when logins occur), BruteForceAttempt (high failed login ratio and volume), intended to detect suspicious auth activity.

Alerts: Prometheus -> Alertmanager -> Telegram

## Grafana
Grafana resources are defined under services/grafana. There's a basic provisioning of datasources and, also, dashboards for an abstract application.

Dashboards are split into 3 cathegories:
- System: visualizes metrics exported by node-exporter, which reflect the changes of system hardware characteristics in time. Four main directions are - CPU, RAM, NET, DISK
- API: provides access to something close to the four golden signals: latencies in various shapes and forms, errors (% of errors), traffic (as RPS). Saturation is rather poorly represented, mostly by system dashboard. Also provides access to logs
- Domain: visualizes basic domain metrics of users/auth systems. Logins, Creations/Deletions of users, Daily/Now Active users.

## Logs & Traces
Logs are expected to be provided by Promtail directly to Loki (which is probably not the best way, yet, it is how it is for now).
Traces, on contrary, are shipped via otel-collector.
In the provisioned grafana datasources it is already configured that logs are bound to traces and vice versa which offers much convenience!

