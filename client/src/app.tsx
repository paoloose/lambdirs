import { Route, Switch } from 'wouter';
import { WithLoggedUser } from './wrappers/with-logged-user';
import { Home } from './components/home/home';
import { OAuthCallback } from './components/no-login/callback';

export function App() {
  return (
    <Switch>
      <Route path='/'>
        <WithLoggedUser>
          <Home />
        </WithLoggedUser>
      </Route>
      <Route path='/callback'>
        <OAuthCallback />
      </Route>
      <Route>404: No such page! 📂</Route>
    </Switch>
  );
}
