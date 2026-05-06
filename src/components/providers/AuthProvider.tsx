/**
 * Project: CloudKart
 * File: AuthProvider.tsx
 * Description: React component with TypeScript.
 * How to use: Rendered as part of the UI.
 * Why it exists: To build the frontend user interface.
 * When it's used: In the browser during user interaction.
 */

'use client';

import { useEffect } from 'react';
import { useDispatch } from 'react-redux';
import { setAuthenticated, setCurrentUser } from '@/lib/features/auth/authSlice';
import fetchData from '@/lib/fetchDataFromApi';

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const dispatch = useDispatch();

  useEffect(() => {
    const checkAuthStatus = async () => {
      try {
        const response = await fetch('/api/auth/check');
        if (response.ok) {
          // Get user data if authenticated
          const userResponse = await fetchData.get('/auth/me');
          if (userResponse?.data) {
            dispatch(setCurrentUser(userResponse.data));
            dispatch(setAuthenticated(true));
          }
        } else {
          // Clear auth state if not authenticated
          dispatch(setAuthenticated(false));
          dispatch(setCurrentUser(null));
          localStorage.removeItem('currentUser');
        }
      } catch (error) {
        console.error('Error checking auth status:', error);
        dispatch(setAuthenticated(false));
        dispatch(setCurrentUser(null));
        localStorage.removeItem('currentUser');
      }
    };

    checkAuthStatus();
  }, [dispatch]);

  return <>{children}</>;
}
