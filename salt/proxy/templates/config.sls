nginx_config:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://ssl_proxy/templates/nginx.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - onchanges_in:
      - service: nginx
    - defaults:
        servers: {{ pillar['ssl_proxy_servers'] }}
        has_extra_config: {{ pillar.extra_nginx_config_template is defined }}

# if extra_nginx_config_template pillar is set, render it into extra.conf
# and include it before the location block. this will support rewrites since
# we can't do it from the ALB.
{% if pillar.extra_nginx_config_template is defined %}
extra_config:
  file.managed:
    - name: /etc/nginx/extra.conf
    - source: {{ pillar['extra_nginx_config_template'] }}
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - onchanges_in:
      - service: nginx
    - defaults:
        servers: {{ pillar['ssl_proxy_servers'] }}
{% endif %}

nginx_ssl_key:
  file.managed:
    - name: /etc/nginx/server.key
    - contents: {{ salt['ssm.get_parameter']('/ssl/internal-key') | yaml_encode }}
    - user: root
    - group: root
    - mode: 600
    - show_changes: false
    - onchanges_in:
      - service: nginx

nginx_ssl_cert:
  file.managed:
    - name: /etc/nginx/server.crt
    - contents: {{ salt['ssm.get_parameter']('/ssl/internal-cert') | yaml_encode }}
    - user: root
    - group: root
    - mode: 600
    - show_changes: false
    - onchanges_in:
      - service: nginx

