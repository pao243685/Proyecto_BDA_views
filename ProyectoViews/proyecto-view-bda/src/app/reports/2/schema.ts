import { z } from "zod";

export const Report2Schema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(5).max(50).default(10)
});

export type Report2Input = z.infer<typeof Report2Schema>;