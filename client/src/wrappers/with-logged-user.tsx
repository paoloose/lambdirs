import { NoLogin } from "@/components/no-login/no-login";
import React, { useEffect } from "react";

interface WithLoggedUserProps {
  children: React.ReactNode;
}

export function WithLoggedUser({ children }: WithLoggedUserProps) {
  const logged = false;

  useEffect(() => {

  }, []);

  if (logged) {
    return children;
  }

  return <NoLogin />;
}
