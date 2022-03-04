# Known issues and limitations

- Power flow algorithms currently work using basic components like 'slack', 'PV' and 'PQ' nodes. ZIP loads or more advanced components are not yet available.
- Both power flow and state estimation algorithms currently do not include explicit models of transformers and voltage regulators.
- Observability check is not yet implemented. State estimation algorithms need an observable measurement set in input.
