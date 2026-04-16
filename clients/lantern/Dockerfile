ARG devnet3_baseimage=piertwo/lantern
ARG devnet3_tag=v0.0.3
ARG devnet4_baseimage=piertwo/lantern
ARG devnet4_tag=v0.0.4

FROM $devnet3_baseimage:$devnet3_tag AS devnet3
FROM $devnet4_baseimage:$devnet4_tag AS devnet4
FROM $devnet3_baseimage:$devnet3_tag

RUN mv /opt/lantern /opt/lantern-devnet3
COPY --from=devnet4 /opt/lantern /opt/lantern-devnet4
ADD lantern.sh /lantern.sh

RUN chmod +x /lantern.sh \
    && devnet3_version="$(LD_LIBRARY_PATH=/opt/lantern-devnet3/lib /opt/lantern-devnet3/bin/lantern --version)" \
    && devnet4_version="$(LD_LIBRARY_PATH=/opt/lantern-devnet4/lib /opt/lantern-devnet4/bin/lantern --version)" \
    && printf "%s\n" "$devnet3_version" | awk '{gsub(/\033\[[0-9;]*m/, ""); print; exit}' > /version-devnet3.txt \
    && printf "%s\n" "$devnet4_version" | awk '{gsub(/\033\[[0-9;]*m/, ""); print; exit}' > /version-devnet4.txt \
    && printf "lantern devnet3: %s\nlantern devnet4: %s\n" \
        "$(cat /version-devnet3.txt)" \
        "$(cat /version-devnet4.txt)" > /version.txt

EXPOSE 5052 9000/udp 8080

ENTRYPOINT ["/lantern.sh"]
