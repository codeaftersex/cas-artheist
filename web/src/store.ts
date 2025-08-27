import { configureStore } from '@reduxjs/toolkit'
import localeSlice from './slices/localeSlice'
import configSlice from './slices/configSlice'


export const store = configureStore({
  reducer: {
    localeSlice,
    configSlice,

  },
})

export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch