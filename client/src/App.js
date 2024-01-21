import './App.css';
import Roles from './actions/Roles';
import Home from './actions/Home';
import Orders from './actions/Orders';
import Operations from './actions/Operations'
import Tracking from './actions/Tracking'
import { BrowserRouter as Router, Switch, Route } from "react-router-dom"

function App() {
  return (
    <div className="App">
      <Router>
        <Switch>
          <Route path="/" exact component={Home} />
          <Route path="/roles" component={Roles} />
          <Route path="/orders" component={Orders} />
          <Route path="/operations" component={Operations} />
          <Route path="/tracking" component={Tracking} />
        </Switch>
      </Router>
    </div>
  );
}

export default App;
