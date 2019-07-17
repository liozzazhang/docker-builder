### Explanation
1. All scripts end with `.sh` located in /config/init/ will be execute by `sh` interpreter, you can check in `resource/main.sh`.
2. `resource/config/init/init.sh`: 
    ```text
    1. apply key/value pairs from consul with token which is store in AWS SSM.
    2. apply key/value pairs from vault with token which is store in AWS SSM.
    3. apply supervisor.conf from template
    ```
3. In any Dockerfile, following `LABEL` can not be empty.
    ```text
    source.image.name=centos7-mini \
    source.image.tag=official \
    source.image.sha256=88d615347f39c00cf598c12f9dd24122b8d45737bfd5a6868434e03c9231d4a0 \
    build.image.name=base18 \
    build.image.version=rel.1.0 \
    maintainer="zlprasy@gmail.com" \
    description="xxx"
    ```
4. In any Dockerfile, `ENTRYPOINT` can not be overwrited.
5. All service must be `started via supervisor`.
6. Any other Dockerfile `FROM` should inherit from `base/base` image.