# Evals

Four cases for `claude plugin eval`, one per skill that can be exercised without a remote:
the summoning on a clean repository, the journal with one quest open, an evocation with
nothing open, and a `--local` quest on a one-line change. Each case builds its own throwaway
fixture with `scaffold.sh` (a tiny Python module with one `unittest` test), so no fixture is
committed and the agent never sees a path into this repository.

```bash
claude plugin eval plugins/rpg --scaffold --allow-tools Bash Write Edit
claude plugin eval plugins/rpg --scaffold --case quest-local-one-line --runs 1
```

`--scaffold` runs the case's `scaffold.sh` as you; read it first. Results land in
`evals/results/`, which is ignored. The runner is early access: on an account without it the
command prints a notice and does nothing, which is what happened when this suite was written —
the cases are checked for shape and their scaffolds for behaviour, not yet scored.
