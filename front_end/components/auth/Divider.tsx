export default function Divider({ text = "or with email" }: { text?: string }) {
  return (
    <div className="relative my-6 flex items-center justify-center">
      <div className="absolute inset-0 flex items-center">
        <div className="w-full border-t border-line" />
      </div>
      <div className="relative bg-canvas px-3 text-xs text-zinc-500 font-medium">
        {text}
      </div>
    </div>
  );
}
