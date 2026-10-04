import AuthShell from "@/components/auth/AuthShell";
import FeatureList from "@/components/auth/FeatureList";
import SignupForm from "@/components/auth/SignupForm";

export default function RegisterPage() {
  return (
    <AuthShell
      side="right"
      form={<SignupForm />}
      marketing={<FeatureList />}
    />
  );
}
