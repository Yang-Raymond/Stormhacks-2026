import type { SVGProps } from "react";

type IconProps = SVGProps<SVGSVGElement>;

function Icon({ className = "size-4", children, ...rest }: IconProps) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      className={className}
      {...rest}
    >
      {children}
    </svg>
  );
}

export const SearchIcon = (p: IconProps) => (
  <Icon {...p}><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></Icon>
);
export const CheckIcon = (p: IconProps) => <Icon {...p}><path d="M20 6 9 17l-5-5" /></Icon>;
export const XIcon = (p: IconProps) => <Icon {...p}><path d="M18 6 6 18M6 6l12 12" /></Icon>;
export const PlusIcon = (p: IconProps) => <Icon {...p}><path d="M12 5v14M5 12h14" /></Icon>;
export const ChevronRightIcon = (p: IconProps) => <Icon {...p}><path d="m9 18 6-6-6-6" /></Icon>;
export const PlayIcon = (p: IconProps) => (
  <Icon {...p}><path d="M7 4.5v15a1 1 0 0 0 1.5.86l12-7.5a1 1 0 0 0 0-1.72l-12-7.5A1 1 0 0 0 7 4.5Z" /></Icon>
);
export const UploadIcon = (p: IconProps) => (
  <Icon {...p}><path d="M12 15V4" /><path d="m7 9 5-5 5 5" /><path d="M5 20h14" /></Icon>
);
export const ResetIcon = (p: IconProps) => (
  <Icon {...p}><path d="M3 12a9 9 0 1 0 3-6.7L3 8" /><path d="M3 3v5h5" /></Icon>
);
export const BugIcon = (p: IconProps) => (
  <Icon {...p}>
    <rect x="8" y="7" width="8" height="13" rx="4" />
    <path d="M9.5 7a2.5 2.5 0 0 1 5 0M12 11v9M8 12H4M20 12h-4M8 16H4.5M19.5 16H16M8.5 8.5 6 6M15.5 8.5 18 6" />
  </Icon>
);
export const SparklesIcon = (p: IconProps) => (
  <Icon {...p}>
    <path d="M11 3 12.9 8.1 18 10l-5.1 1.9L11 17l-1.9-5.1L4 10l5.1-1.9Z" />
    <path d="M19 15.5 19.8 17.2 21.5 18l-1.7.8L19 20.5l-.8-1.7-1.7-.8 1.7-.8Z" />
  </Icon>
);
export const TerminalIcon = (p: IconProps) => (
  <Icon {...p}><path d="m5 17 5-5-5-5" /><path d="M12 19h7" /></Icon>
);
export const FlaskIcon = (p: IconProps) => (
  <Icon {...p}>
    <path d="M9 3h6M10 3v6l-5.4 9.7A1.5 1.5 0 0 0 5.9 21h12.2a1.5 1.5 0 0 0 1.3-2.3L14 9V3" />
    <path d="M7.5 15h9" />
  </Icon>
);
export const FileTextIcon = (p: IconProps) => (
  <Icon {...p}>
    <path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8Z" />
    <path d="M14 3v5h5M9 13h6M9 17h6" />
  </Icon>
);
export const ContinueIcon = (p: IconProps) => (
  <Icon {...p}><path d="M5 5v14" /><path d="M9 5.5v13a1 1 0 0 0 1.5.86l9-6.5a1 1 0 0 0 0-1.72l-9-6.5A1 1 0 0 0 9 5.5Z" /></Icon>
);
export const ReverseContinueIcon = (p: IconProps) => (
  <Icon {...p}><path d="M19 5v14" /><path d="M15 5.5v13a1 1 0 0 1-1.5.86l-9-6.5a1 1 0 0 1 0-1.72l9-6.5A1 1 0 0 1 15 5.5Z" /></Icon>
);
export const StepOverIcon = (p: IconProps) => (
  <Icon {...p}><path d="M4 13a8 8 0 0 1 15.4-3" /><path d="M20 4v6h-6" /><circle cx="12" cy="19" r="1.6" /></Icon>
);
export const StepBackIcon = (p: IconProps) => (
  <Icon {...p}><path d="M20 13a8 8 0 0 0-15.4-3" /><path d="M4 4v6h6" /><circle cx="12" cy="19" r="1.6" /></Icon>
);
export const StepIntoIcon = (p: IconProps) => (
  <Icon {...p}><path d="M12 3v10" /><path d="m7.5 8.5 4.5 4.5 4.5-4.5" /><circle cx="12" cy="19" r="1.6" /></Icon>
);
export const StepOutIcon = (p: IconProps) => (
  <Icon {...p}><path d="M12 14V4" /><path d="m7.5 8.5 4.5-4.5 4.5 4.5" /><circle cx="12" cy="19" r="1.6" /></Icon>
);
export const StopIcon = (p: IconProps) => <Icon {...p}><rect x="6" y="6" width="12" height="12" rx="2" /></Icon>;
export const RestartIcon = (p: IconProps) => (
  <Icon {...p}><path d="M21 12a9 9 0 1 1-3-6.7L21 8" /><path d="M21 3v5h-5" /></Icon>
);
export const LogOutIcon = (p: IconProps) => (
  <Icon {...p}><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" /><path d="m16 17 5-5-5-5M21 12H9" /></Icon>
);

export const CodeIcon = (p: IconProps) => (
  <Icon {...p}><path d="m16 18 6-6-6-6M8 6l-6 6 6 6" /></Icon>
);
export const CrosshairIcon = (p: IconProps) => (
  <Icon {...p}><circle cx="12" cy="12" r="3" /><path d="M12 2v4M12 18v4M2 12h4M18 12h4" /></Icon>
);
export const LightbulbIcon = (p: IconProps) => (
  <Icon {...p}>
    <path d="M9 18h6M10 22h4" />
    <path d="M12 2a7 7 0 0 0-4 12.7c.6.5 1 1.3 1 2.1V17h6v-.2c0-.8.4-1.6 1-2.1A7 7 0 0 0 12 2Z" />
  </Icon>
);
export const BarChartIcon = (p: IconProps) => (
  <Icon {...p}><path d="M3 21h18M7 17V11M12 17V5M17 17v-3" /></Icon>
);
export const CalendarIcon = (p: IconProps) => (
  <Icon {...p}>
    <rect x="3" y="5" width="18" height="16" rx="2" />
    <path d="M16 3v4M8 3v4M3 10h18M8 14h.01M12 14h.01M16 14h.01M8 17h.01M12 17h.01" />
  </Icon>
);
export const MessageSquareIcon = (p: IconProps) => (
  <Icon {...p}><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2Z" /></Icon>
);

