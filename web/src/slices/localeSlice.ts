import { createSlice } from '@reduxjs/toolkit';

export interface LocaleState {
    locale: {
        [key: string]: string | number | Object
    };
}

const initialState: LocaleState = {
    locale: {}
};

const localeSlice = createSlice({
    name: 'locale',
    initialState,
    reducers: {
        setLocale: (state, action) => {
            state.locale = action.payload
        }
    },
});

export const { setLocale } = localeSlice.actions;
export default localeSlice.reducer;