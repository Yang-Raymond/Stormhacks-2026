import Logo from "./Logo";

interface AuthShellProps {
  side: "left" | "right";
  form: React.ReactNode;
  marketing: React.ReactNode;
}

export default function AuthShell({ side, form, marketing }: AuthShellProps) {
  return (
    <div className="min-h-screen w-full flex flex-col lg:grid lg:grid-cols-2 bg-canvas text-zinc-100">
      {side === "left" ? (
        <>
          {/* Left: Form side (Log in) */}
          <section className="relative flex flex-col justify-between p-6 sm:p-10 lg:p-12 min-h-screen lg:border-r lg:border-line">
            <div>
              <Logo />
            </div>
            <div className="my-auto py-8 flex justify-center">
              <div className="w-full max-w-[390px]">
                {form}
              </div>
            </div>
            <div className="hidden lg:block text-xs text-zinc-600">
              &copy; {new Date().getFullYear()} LadyBug
            </div>
          </section>

          {/* Right: Marketing/Preview side */}
          <section className="hidden lg:flex flex-col justify-center items-center p-12 bg-canvas-2 relative overflow-hidden">
            <div className="w-full max-w-[450px]">
              {marketing}
            </div>
          </section>
        </>
      ) : (
        <>
          {/* Left: Marketing/Feature side (Sign up) */}
          <section className="relative flex flex-col justify-between p-6 sm:p-10 lg:p-12 lg:border-r lg:border-line">
            <div>
              <Logo />
            </div>
            <div className="my-auto py-8 hidden lg:flex justify-center">
              <div className="w-full max-w-[430px]">
                {marketing}
              </div>
            </div>
            <div className="hidden lg:block text-xs text-zinc-600">
              &copy; {new Date().getFullYear()} LadyBug
            </div>
          </section>

          {/* Right: Form side */}
          <section className="flex flex-col justify-center items-center p-6 sm:p-10 lg:p-12 bg-canvas-2 min-h-screen lg:min-h-0">
            <div className="w-full max-w-[410px]">
              {form}
            </div>
          </section>
        </>
      )}
    </div>
  );
}
