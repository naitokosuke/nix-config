# Task Completion Checklist

After completing a task, run the following:

1. **Format code**:
   ```bash
   nix fmt
   ```

2. **Apply and test changes**:
   ```bash
   sudo darwin-rebuild switch --flake .#Mac-big
   ```

3. **Verify no errors** in the switch output
