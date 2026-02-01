import { z } from "zod";

export const Report5Schema = z.object({
  nivelVentas: z.enum(["ALTA", "MEDIA", "BAJA"]).optional()
});

export type Report5Input = z.infer<typeof Report5Schema>;