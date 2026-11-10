import Image from "next/image"
import { cn } from "@/lib/utils"

export interface MatrixLogoProps {
  className?: string
  markOnly?: boolean
  alt?: string
}

/**
 * EVC Brand Logo component.
 *
 * Renders the EVC Logo for light and dark themes using `/images/evc-logo-light.png`
 * and `/images/evc-logo-dark.png`, or the isometric mark `/images/evc-mark.png` when `markOnly` is true.
 * Designed with zero white background, zero box-shadow, and zero glow artifacts.
 */
export function MatrixLogo({
  className,
  markOnly = false,
  alt = "EVC",
}: MatrixLogoProps) {
  if (markOnly) {
    return (
      <span
        role="img"
        aria-label={alt}
        className={cn(
          "relative inline-flex items-center justify-center shrink-0 aspect-square bg-transparent shadow-none",
          className
        )}
      >
        <Image
          src="/images/evc-mark.png"
          alt={alt}
          width={512}
          height={512}
          priority
          className="h-full w-full object-contain"
        />
      </span>
    )
  }

  return (
    <span
      role="img"
      aria-label={alt}
      className={cn(
        "relative inline-flex items-center justify-center shrink-0 aspect-[568/230] bg-transparent shadow-none",
        className
      )}
    >
      <Image
        src="/images/evc-logo-light.png"
        alt={alt}
        width={568}
        height={230}
        priority
        className="h-full w-full object-contain dark:hidden"
      />
      <Image
        src="/images/evc-logo-dark.png"
        alt={alt}
        width={568}
        height={230}
        priority
        className="hidden h-full w-full object-contain dark:block"
      />
    </span>
  )
}

export const EvcLogo = MatrixLogo
