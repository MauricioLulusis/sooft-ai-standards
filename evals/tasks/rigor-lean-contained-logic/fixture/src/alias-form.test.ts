// Suite existente — no cubre espacios al inicio/final todavía.
import { validateAlias } from "./alias-form";

test("acepta un alias simple", () => {
  expect(validateAlias("juan123")).toBe(true);
});
