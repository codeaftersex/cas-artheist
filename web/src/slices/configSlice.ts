import { createSlice } from '@reduxjs/toolkit';

export interface ConfigState {
    config: {
        [key: string]: string | number | Object;
    };
}

const initialState: ConfigState = {
    config: {
        Swipers: [
            {
                img: "https://via.placeholder.com/800x400", // Fake görsel
                swiperHeader: "Fake Swiper 1",
                description: "This is a description for Fake Swiper 1",
                button: "Learn More",
                buttonLink: "#"
            },
            {
                img: "https://via.placeholder.com/800x400",
                swiperHeader: "Fake Swiper 2",
                description: "This is a description for Fake Swiper 2",
                button: "Explore",
                buttonLink: "#"
            }
        ]
    }
};

const configSlice = createSlice({
    name: 'config',
    initialState,
    reducers: {
        setConfig: (state, action) => {
            state.config = action.payload;
        },
        setDefaultLocale: (state, action) => {
            if (state.config) {
                state.config.Locale = action.payload; 
            }
        },
    },
});

export const { setConfig, setDefaultLocale } = configSlice.actions;
export default configSlice.reducer;
