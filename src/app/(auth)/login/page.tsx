/**
 * Project: CloudKart
 * File: page.tsx
 * Description: React component with TypeScript.
 * How to use: Rendered as part of the UI.
 * Why it exists: To build the frontend user interface.
 * When it's used: In the browser during user interaction.
 */

import Logo from "@/assets/Logo";
import { LoginForm } from "@/components/forms/LoginForm";
import Link from "next/link";

const LoginPage = () => {
  return (
    <div className="max-w-xl px-default mx-auto pt-12 pb-20">
      <div className="flex text-center flex-col items-center">
        <Logo />
        <p className="my-3">Login with your email & password</p>
      </div>
      <LoginForm />
      <div className="flex-1 h-0.5 bg-muted my-6"></div>

      <p className="text-center">
        Don&apos;t have any account?{" "}
        <Link
          href={"/register"}
          type="button"
          className="text-primary hover:underline"
        >
          Register
        </Link>
      </p>
    </div>
  );
};

export default LoginPage;
