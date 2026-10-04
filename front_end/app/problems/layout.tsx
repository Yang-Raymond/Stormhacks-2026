// Pages set their own padding: the list is a centered column, the workspace is full-bleed.
export default function ProblemsLayout({ children }: { children: React.ReactNode }) {
  return <div className="flex flex-1 flex-col">{children}</div>;
}
