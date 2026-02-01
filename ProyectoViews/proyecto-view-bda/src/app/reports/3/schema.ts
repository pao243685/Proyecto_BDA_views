import { z } from "zod";

export const Report3Schema = z.object({
    categoria: z.string().optional(),
    page: z.coerce.number().min(1).default(1),
    limit: z.coerce.number().min(5).max(50).default(10)
});

export type Report3Input = z.infer<typeof Report3Schema>;
