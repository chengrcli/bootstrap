**NOTE:** systemd-resolved doesn't forward single-label dns request.
It means we can't access other VMs via hosts name.

single-label issue: https://github.com/systemd/systemd/issues/13763
