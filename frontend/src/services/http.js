import axios from 'axios'

const http = axios.create({
  baseURL: '/api',
  withCredentials: true, // sends httpOnly cookie on every request
  headers: { 'Content-Type': 'application/json' },
})

http.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      // Let the router guard or store handle the redirect
      window.dispatchEvent(new CustomEvent('auth:unauthorized'))
    }
    return Promise.reject(err)
  },
)

export default http
